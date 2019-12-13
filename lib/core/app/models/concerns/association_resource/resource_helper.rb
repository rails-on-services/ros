# frozen_string_literal: true

module AssociationResource
  # rubocop:disable Metrics/ModuleLength
  module ResourceHelper
    extend ActiveSupport::Concern

    # Overrided relationship method to return desired resource type
    # rubocop:disable Style/ClassAndModuleChildren
    class JSONAPI::Relationship
      def type_for_source(source)
        resource = source.public_send(name)
        return resource.class._type if resource.is_a? AssociationResource::IncludedResource
        return resource&.type if polymorphic?

        type
      end
    end
    # rubocop:enable Style/ClassAndModuleChildren

    # rubocop:disable Metrics/BlockLength
    class_methods do
      # NOTE: This has been copied directly from the jsonapi resources class with
      # the small change that fixes the bug they have for this version.
      # The bug has been reported (https://github.com/cerebris/jsonapi-resources/issues/1299)
      # I've also proposed the bug fix (https://github.com/cerebris/jsonapi-resources/pull/1300)
      # but it has not been addressed yet. Once we upgrade to jsonapi 0.10.x
      # this should definitely be removed.
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Style/PreferredHashMethods
      def original_preload_included_fragments(resources, records, serializer, options)
        return if resources.empty?

        res_ids = resources.keys

        include_directives = options[:include_directives]
        return unless include_directives

        context = options[:context]

        # For each association, including indirect associations, find the target record ids.
        # Even if a target class doesn't have caching enabled, we still have to look up
        # and match the target ids here, because we can't use ActiveRecord#includes.
        #
        # Note that `paths` returns partial paths before complete paths, so e.g. the partial
        # fragments for posts.comments will exist before we start working with posts.comments.author
        target_resources = {}

        include_directives.paths.each do |path|
          # If path is [:posts, :comments, :author], then...
          pluck_attrs = [] # ...will be [posts.id, comments.id, authors.id, authors.updated_at]
          pluck_attrs << _model_class.arel_table[_primary_key]

          relation = records.except(:limit, :offset, :order)
                            .where(_primary_key => res_ids)

          # These are updated as we iterate through the association path; afterwards they will
          # refer to the final resource on the path, i.e. the actual resource to find in the cache.
          # So e.g. if path is [:posts, :comments, :author], then after iteration...
          parent_klass = nil # Comment
          klass = self # Person
          relationship = nil # JSONAPI::Relationship::ToOne for CommentResource.author
          table = nil # people
          assocs_path = [] # [ :posts, :approved_comments, :author ]
          ar_hash = nil # { :posts => { :approved_comments => :author } }

          # For each step on the path, figure out what the actual table name/alias in the join
          # will be, and include the primary key of that table in our list of fields to select
          non_polymorphic = true

          path.each do |elem|
            relationship = klass._relationships[elem]
            if relationship.polymorphic
              # Can't preload through a polymorphic belongs_to association, ResourceSerializer
              # will just have to bypass the cache and load the real Resource.
              non_polymorphic = false
              break
            end
            assocs_path << relationship.relation_name(options).to_sym
            # Converts [:a, :b, :c] to Rails-style { :a => { :b => :c }}
            ar_hash = assocs_path.reverse.reduce { |memo, step| { step => memo } }
            # We can't just look up the table name from the resource class, because Arel could
            # have used a table alias if the relation includes a self-reference.
            join_source = relation.joins(ar_hash).arel.source.right.reverse.find do |arel_node|
              arel_node.is_a?(Arel::Nodes::InnerJoin)
            end
            table = join_source.left

            parent_klass = klass
            klass = relationship.resource_klass
            pluck_attrs << table[klass._primary_key]
          end

          next unless non_polymorphic

          # Pre-fill empty hashes for each resource up to the end of the path.
          # This allows us to later distinguish between a preload that returned nothing
          # vs. a preload that never ran.
          prefilling_resources = resources.values
          path.each do |rel_name|
            rel_name = serializer.key_formatter.format(rel_name)
            prefilling_resources.map! do |res|
              res.preloaded_fragments[rel_name] ||= {}
              res.preloaded_fragments[rel_name].values
            end
            prefilling_resources.flatten!(1)
          end

          pluck_attrs << table[klass._cache_field] if klass.caching?
          relation = relation.joins(ar_hash)
          if relationship.is_a?(::JSONAPI::Relationship::ToMany)
            # Rails doesn't include order clauses in `joins`, so we have to add that manually here.
            # FIXME Should find a better way to reflect on relationship ordering. :-(
            relation = relation.order(parent_klass._model_class.new.send(assocs_path.last).arel.orders)
          end

          # [[post id, comment id, author id, author updated_at], ...]
          id_rows = pluck_arel_attributes(relation.joins(ar_hash), *pluck_attrs)

          target_resources[klass.name] ||= {}

          if klass.caching?
            sub_cache_ids = id_rows
                            .map { |row| row.last(2) }
                            .reject { |row| target_resources[klass.name].has_key?(row.first) }
                            .uniq
            target_resources[klass.name].merge! CachedResourceFragment.fetch_fragments(
              klass, serializer, context, sub_cache_ids
            )
          else
            sub_res_ids = id_rows
                          .map(&:last)
                          .reject { |id| target_resources[klass.name].has_key?(id) }
                          .uniq
            found = klass.find({ klass._primary_key => sub_res_ids }, context: options[:context])
            target_resources[klass.name].merge! found.map { |r| [r.id, r] }.to_h
          end

          id_rows.each do |row|
            res = resources[row.first]
            path.each_with_index do |rel_name, index|
              rel_name = serializer.key_formatter.format(rel_name)
              rel_id = row[index + 1]
              assoc_rels = res.preloaded_fragments[rel_name]
              if index == path.length - 1
                association_res = target_resources[klass.name].fetch(rel_id, nil)
                assoc_rels[rel_id] = association_res if association_res
              else
                res = assoc_rels[rel_id]
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Style/PreferredHashMethods

      def preload_included_fragments(resources, records, serializer, options)
        return if resources.empty?

        include_directives = options[:include_directives]
        return unless include_directives

        array_includes = include_directives.include_directives[:include_related]
        resources_array = array_includes.select { |res| _model_class.find_resource(res) }

        # Exclude non active-record includes
        array_includes.except!(*resources_array.keys)

        # NOTE: calling monkeypatched json api method that fixes the bug
        # Read note above
        original_preload_included_fragments(resources, records, serializer, options)
        # return non active-record includes
        array_includes.merge!(resources_array)
      end

      def belongs_to_resource(resource)
        resource_name = resource.to_s.singularize
        define_new_resource(resource_name)
        has_one resource.to_sym, class_name: "AssociationResource::#{resource_name}"
      end

      # rubocop:disable Naming/PredicateName
      def has_many_resources(resources)
        resource_name = resources.to_s.singularize
        define_new_resource(resource_name)
        has_many resources.to_sym, class_name: "AssociationResource::#{resource_name}"
        define_method("records_for_#{resources}") { |_| _model.send(resources.to_sym) }
      end
      # rubocop:enable Naming/PredicateName

      private

      # Dynamically define resource class for each external resource
      def define_new_resource(resource_name)
        name = resource_name.singularize
        resource_klass_name = name.to_s.camelcase
        klass_name = "#{resource_klass_name}Resource"
        return if AssociationResource.const_defined? klass_name

        base_klass = AssociationResource::IncludedResource
        base_klass.sub_name = name
        AssociationResource.const_set(klass_name, Class.new(base_klass))
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end

# frozen_string_literal: true

fn = File.expand_path(File.dirname(__FILE__))
require 'pry'
binding.pry
Spring.application_root = './spec/dummy'

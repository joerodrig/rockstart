# frozen_string_literal: true

include "rockstart/base_generator"

class Rockstart::ScaffoldTemplatesGenerator < Rockstart::BaseGenerator
  source_root File.expand_path("templates", __dir__)

  class_option :pundit, type: :boolean,
                        desc: "Include Pundit support",
                        default: true

  def copy_scaffold_templates
    template "api_controller.rb.tt", "lib/templates/rails/scaffold_controller/api_controller.rb.tt"
    template "controller.rb.tt", "lib/templates/rails/scaffold_controller/controller.rb.tt"
  end

  def copy_rspec_scaffold_templates
    copy_file "rspec/scaffold/api_request_spec.rb",
              "#{rspec_templates_dir}/scaffold/api_request_spec.rb"
    copy_file "rspec/scaffold/request_spec.rb",
              "#{rspec_templates_dir}/scaffold/request_spec.rb"
  end

  private

  def pundit?
    options[:pundit]
  end

  def rspec_templates_dir
    @rspec_templates_dir ||= "lib/templates/rspec"
  end
end

# frozen_string_literal: true

class Rockstart::DeviseGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  class_option :skip_model, type: :boolean,
                            desc: "Skip model generation",
                            default: false

  def install_devise
    gem "devise"

    Bundler.clean_system("bundle install --quiet")

    Bundler.with_clean_env do
      Dir.mktmpdir do |dir|
        generate_devise_install(dir)
        directory File.join(dir, "config"), "config"
      end
    end
  end

  def generate_user_model
    return if options[:skip_model]

    Bundler.with_clean_env do
      generate "devise", "User", "--primary-key-type=uuid"
    end
  end

  def add_rspec_coverage
    directory "spec"
  end

  def update_users_factory
    inject_into_file "spec/factories/users.rb", after: "factory :user do\n" do
      <<~'FACTORY'.gsub(/([^\n]*)\n/, "    \\1\n")
        email { Faker::Internet.email }
        password { Faker::Lorem.words(number: 3).join }
      FACTORY
    end
  end

  private

  def generate_devise_install(dir)
    require "generators/devise/install_generator"

    initializer = ::Devise::Generators::InstallGenerator.new(
      report_stream: StringIO.new
    )
    initializer.destination_root = dir
    initializer.invoke_all

    update_initializer(dir)
  end

  def update_initializer(dir)
    gsub_file File.join(dir, "config", "initializers", "devise.rb"),
              /config\.mailer_sender = ['"][^'"]+['']/,
              'config.mailer_sender = ENV.fetch("DEVISE_MAILER_SENDER", Rails.application.credentials.devise_mailer_sender)'
    gsub_file File.join(dir, "config", "initializers", "devise.rb"),
              /config\.secret_key = ['"][^'"]+['']/,
              'config.secret_key = ENV.fetch("DEVISE_SECRET_KEY")'
    gsub_file File.join(dir, "config", "initializers", "devise.rb"),
              /config\.pepper = ['"][^'"]+['']/,
              'config.pepper = ENV.fetch("DEVISE_PEPPER")'
  end
end

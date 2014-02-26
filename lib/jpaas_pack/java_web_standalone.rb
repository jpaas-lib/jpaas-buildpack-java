require "fileutils"
require "jpaas_pack/java"

module JpaasPack
  class JavaWebStandalone < Java

    def self.use?
      File.exists?("bin/catalina.sh") && Dir.glob("**/web.xml").any?
    end

    def name
      "Java Web Standalone:Tomcat"
    end

    def do_compile
      install_java
      setup_profiled
    end

    def remove_tomcat_files
      %w[NOTICE RELEASE-NOTES RUNNING.txt LICENSE temp/. work/. logs].each do |file|
        FileUtils.rm_rf("#{tomcat_dir}/#{file}")
      end
    end

    def tomcat_dir
      build_dir
    end

    def java_opts
      opts = super.merge({ "-Dhttp.port=" => "$PORT" })
      opts
    end

    def default_process_types
      {
        "web" => "./bin/catalina.sh run"
      }
    end

  end
end

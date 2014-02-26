require "fileutils"
require "jpaas_pack/java"

module JpaasPack
  class JavaWeb < Java

    def self.use?
      File.exists?("WEB-INF/web.xml") || File.exists?("webapps/ROOT/WEB-INF/web.xml")
    end

    def name
      "Java Web:Tomcat"
    end

    def do_compile
      install_java
      install_tomcat
      remove_tomcat_files
      copy_webapp_to_tomcat
      move_tomcat_to_root
      copy_tomcat_conf
      setup_profiled
    end

    def install_tomcat
      FileUtils.mkdir_p tomcat_dir

      download_tomcat(tomcat_tarball)

      puts "INFO: Unpacking Tomcat to #{tomcat_dir}"
      run_with_err_output("tar xzf #{tomcat_tarball} -C #{tomcat_dir} && mv #{tomcat_dir}/apache-tomcat*/* #{tomcat_dir} && rm -rf #{tomcat_dir}/apache-tomcat*")
      FileUtils.rm_rf tomcat_tarball

      unless File.exists?("#{tomcat_dir}/bin/catalina.sh")
        puts "Unable to retrieve Tomcat"
        exit 1
      end
      puts "INFO: Unpacking Tomcat to #{tomcat_dir} is done"

    end

    def tomcat_tarball
      "#{tomcat_dir}/tomcat.tar.gz"
    end

    def remove_tomcat_files
      %w[NOTICE RELEASE-NOTES RUNNING.txt LICENSE temp/. webapps/. work/. logs].each do |file|
        FileUtils.rm_rf("#{tomcat_dir}/#{file}")
      end
    end

    def tomcat_dir
      ".tomcat"
    end

    def webapp_path
      File.join(build_path,"webapps","ROOT")
    end

    def copy_webapp_to_tomcat
      run_with_err_output("mkdir -p #{tomcat_dir}/webapps/ROOT && mv * #{tomcat_dir}/webapps/ROOT")
    end

    def copy_tomcat_conf
      run_with_err_output("cp -rf #{File.expand_path('../../../resources/conf', __FILE__)} #{build_path}")
    end

    def move_tomcat_to_root
      run_with_err_output("mv #{tomcat_dir}/* . && rm -rf #{tomcat_dir}")
    end

    def java_opts
      opts = super.merge({ "-Dhttp.port=" => "$PORT" })
      opts.delete("-Djava.io.tmpdir=")
      opts
    end

    def default_process_types
      {
        "web" => "./bin/catalina.sh run"
      }
    end

  end
end

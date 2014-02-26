module JpaasPack
  module Packager
    
    def download_jdk(jdk_tarball)
      puts "INFO: copying JDK from local resources ..."
      copy_from_local(jdk,jdk_tarball)
      puts "INFO: copying JDK from local resources is done"
    end

    def download_tomcat(tomcat_tarball)
      puts "INFO: copying Tomcat from local resources ..."
      copy_from_local(tomcat,tomcat_tarball)
      puts "INFO: copying Tomcat from local resources is done"
    end

    def copy_from_local(src_file, des_file)
      begin
        FileUtils.cp(src_file, des_file)
      rescue
        puts "FATAL: copying from local resources failed"
        exit 1
      end
    end

    def jdk
      File.join(resources,"jdk/jdk1.6.tar.gz")
    end

    def tomcat
      File.join(resources,"tomcat/apache-tomcat-6.tar.gz")
    end

    def resources
      File.expand_path('../../../resources/', __FILE__)
    end

  end
end

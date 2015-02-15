require 'yaml'

require 'mongo_sync/version'
require 'mongo_sync/config'

module MongoSync
    def self.pull(config = nil)
        configs  = MongoSync::Configuration.parse(config)
        tmpdir   = tmp_dir

        puts       "Dumping Remote DB to #{tmpdir}..." 
        system_run "mongodump \
                        -h #{configs['remote']['host']['url']}:#{configs['remote']['host']['port']} \
                        -d #{configs['remote']['db']} \
                        -u #{configs['remote']['access']['username']} \
                        -p #{configs['remote']['access']['password']} \
                        -o #{tmpdir} > /dev/null"

        puts        "Overwriting Local DB..."
        system_run  "mongorestore \
                        -d #{configs['local']['db']} \
                        #{tmpdir}/#{configs['remote']['db']} \
                        --drop > /dev/null"

        clean_up
        done_msg
    end
    
    def self.push(config = nil)
        configs = MongoSync::Configuration.parse(config)
        tmpdir  = tmp_dir
    end

    
    private
    
    def self.tmp_dir
        "/tmp/mongo_sync/#{Time.now.to_i}"
    end

    def self.success_msg
        puts 'Success!', ''
    end

    def self.done_msg
        puts 'Done!', ''
    end

    def self.clean_up(dir)
        puts        "Cleaning Up..."
        system_run  "rm -rf #{dir}"
        success_msg
    end

    def self.system_run(command)
        raise SystemCommandFailed.new("System Command '#{command}' Failed") if not system(command)
        success_msg
    end

    class SystemCommandFailed < StandardError; end
end
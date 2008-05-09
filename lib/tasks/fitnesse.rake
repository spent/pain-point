namespace :fitnesse do

  namespace :server do
    desc "Start the fitnesse server"
    task :start do
      Process.fork{system "java -cp vendor/fitnesse/fitnesse.jar fitnesse.FitNesse -o -e 0 -p 8081 -r test/fitnesse/WikiRoot"}
    end

    desc "Stop the fitnesse server"
    task :stop do
      system "java -cp vendor/fitnesse/fitnesse.jar fitnesse.Shutdown -p 8081 "
    end
  end

end

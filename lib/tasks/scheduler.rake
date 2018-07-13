desc "This task is called by the Heroku scheduler add-on (cron job, basically)"
task :evaluate_plans => :environment do
  puts "Evaluating plans..."
  Plan.where(succeeded: nil).each do |plan|
  	plan.evaluate
  	# TODO: error handling/notification
  end
  puts "done."
end

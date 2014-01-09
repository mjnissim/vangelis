namespace 'application' do
  desc "Upgrade to generated assignments"
  task :upgrade => :environment do
    Assignment.all.each do |a|
      a.update_attributes status: Assignment::STATUSES[:completed]
    end
  end
end
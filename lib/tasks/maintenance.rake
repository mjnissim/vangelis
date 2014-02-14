namespace 'application' do
  desc "Upgrade to generated assignments"
  task :upgrade => :environment do
    User.first.update_attributes nickname: 'Elon'
  end
end
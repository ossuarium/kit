guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/kit/(.+)\.rb$}) { |m| "spec/kit_#{m[1]}_spec.rb" }
  watch(%r{^lib/kit/models/(.+)\.rb$}) { |m| "spec/models/#{m[1]}_spec.rb" }
end

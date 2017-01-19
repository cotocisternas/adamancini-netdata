require 'json'
Facter.add(:netdata_charts) do
  setcode do
    charts_hash = {}
    charts_hash = Facter::Util::Resolution.exec('/usr/bin/curl -X GET http://localhost:19999/api/v1/charts')
    JSON.pretty_generate(charts_hash, opts = nil)
  end
end
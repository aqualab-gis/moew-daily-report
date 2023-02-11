require "json"
require "csv"

TABLE_REGEX_A = /^(?<id>\d+) +(?<basin_directorate>БД.+?) +(?<name>[^0-9]+?)(  не|((?<total_volume>[0-9,.]+) +)?(?<sanitary_volume>[0-9,.]+) +(?<current_volume>[0-9,.]+) +(?<current_volume_percent>[0-9,.]+%) +(?<current_useful_volume>[0-9,.]+) +(?<current_useful_volume_percent>[0-9,.]+%) +((?<ingress>[0-9,.]+) +(?<egress>[0-9,.]+) +)?.*(?<trend>[^ ]+)$)/

Dir["parsed_data/text/*.txt"].each do |file|
  parsed_report = File.read(file)
    .lines
    .select { _1 =~ /^ *\d+ +БД/ }
    .map(&:strip)
    .map do |row|
      TABLE_REGEX_A.match(row).named_captures
    rescue
      warn "#{file}: Could not parse #{row}"
    end

  parsed_report.compact!

  parsed_report.each do |entry|
    entry["id"] = entry["id"].to_i
    entry["name"].strip!

    %w[total_volume sanitary_volume current_volume current_volume_percent current_useful_volume current_useful_volume_percent ingress egress].each do
      next unless entry[_1]
      entry[_1] = entry[_1].delete("%").gsub(",", ".").to_f
    end
  end

  File.write(File.join('parsed_data', 'json', File.basename(file, '.txt')) + '.json', parsed_report.to_json)
  CSV.open(File.join('parsed_data', 'csv', File.basename(file, '.txt')) + '.csv', "w", headers: parsed_report.first.keys) do |csv|
    csv << parsed_report.first.keys
    parsed_report.each do |row|
      csv << row.values
    end
  end
end

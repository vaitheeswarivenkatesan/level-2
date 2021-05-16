def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

dns_raw = File.readlines("zone")

# This function returns hashes of records in zone file
def parse_dns(raw)
  raw.
    reject { |line| line.empty? }.
    map { |line| line.strip.split(", ") }.
    reject { |record| record.length < 3 }.
    each_with_object({}) do |record, records|
    records[record[1]] = {
      type: record[0],
      target: record[2],
    }
  end
end

# This function is to find the result for domain name until it resolves to an IPv4
def resolve(dns_records, lookup_chain, domain)
  record = dns_records[domain]
  if (!record)
    lookup_chain = ["Error: Record not found for " + domain]
    return lookup_chain
  elsif record[:type] == "CNAME"
    lookup_chain << record[:target]
    return resolve(dns_records, lookup_chain, record[:target])
  elsif record[:type] == "A"
    return lookup_chain << record[:target]
  else
    lookup_chain << "Invalid record type for " + domain
    return
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")

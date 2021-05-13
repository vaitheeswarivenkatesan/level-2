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

dns_raw = File.readlines("zone",chomp:true)

# This function returns hashes of records in zone file
def parse_dns(dns_raw)
	dns_records={:record=>[],:source=>[],:destination=>[]}
	keys=dns_records.keys
	dns_raw.each{
		|line| 
		words=line.split(",").collect(&:strip)
		words.each.with_index{|value,index|
			dns_records[dns_records[keys[index]].push(value)]
		}
	}
	return dns_records
end

# This function is to find the result for domain name until it resolves to an IPv4
def resolve(dns_records,lookup_chain,domain)
	found=false
	dns_records[:source].each.with_index{|value,index|
		if (value==domain && dns_records[:record][index]=="A")
			lookup_chain.push(dns_records[:destination][index])
			found=true
			break
		elsif(value == domain)
			lookup_chain.push(dns_records[:destination][index])
			return resolve(dns_records,lookup_chain,dns_records[:destination][index])
		end
	}
	# if the domain doesnt exist in the zonefile
	if(!found)
	   lookup_chain=["Error: record not found for #{domain}"]
    end

	return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
# p dns_records
lookup_chain=[domain]
lookup_chain = resolve(dns_records,lookup_chain,domain)
puts lookup_chain.join(" => ")




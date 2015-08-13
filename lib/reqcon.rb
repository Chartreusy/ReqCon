require "reqcon/version"
require 'yaml'
# we want to take in a list of requirements/constraints
# and a list of parameters/values and then run them against each other.
module Reqcon
    # takes instances of parameters and tabulates them in results accordingly
    # TODO: Handle value ranges for reqcon value
    # x-y : range between x and y inclusive
    # x+ : more than x
    # x- : less than x
    # should we be counting the excess like this? in the regex version, what if we want one to fulfill multiple?
    # e.g.: "i need 20 CS courses, of them being 240, 241, etc.?"
    # soln: keep it separate. Totals option.
    # Fulfilling requirements should always be like putting balls in buckets.
    # TODO: Regex overlap? [1-3]|[4-9] \n [4-9]
    # not sure if we can do that. can we just recommend increasing restrictivity in input?
    def count(key, needed, parvals, results)
        value = parvals['parameters'][key]
        parvals['parameters'].delete(key)
        if value > needed # fill the box, return excess
            results['met'][key] = needed
            parvals['parameters'][key] = value - needed
        elsif value < needed then # empty into the box
            results['met'][key] = needed - value
        else
            results['met'][key] = needed
        end
    end

    def run(reqcons, parvals)
        results = Hash.new
        results['met'] = Hash.new
        results['excess'] = Hash.new
        results['missing'] = Hash.new
        puts reqcons.inspect
        puts parvals.inspect
        if parvals['parameters'].class != Hash
            puts "parvals['requirements'] is #{parvals['parameters'].class}"
            #then we convert it into a hash
            # should allow list, string...any others?
            # TODO: List aggregation into hash. That'll make me happy with the flexibility.
            params = Hash.new
            parvals['parameters'].each do |item|
                params.has_key?(item) ? params[item] = params[item]+1 : params[item] = 1
            end
            parvals['parameters'] = params
        end

        # if regex is on, then we have to do M*N comparisons. If it is NOT on,
        # then we can actually ge M time instead
        if reqcons['config']['regex']
            # iterate through requirements, apply each regex to each value
            reqcons['requirements'].each do |search, value|
                regx = Regexp.new("#{search.to_s}") unless search.is_a?(Regexp)
                found = false
                parvals['parameters'].each do |key, v|
                    if key =~ regx
                        count(key, value, parvals, results)
                        found = true
                    end
                end
                results['missing'][search] = value unless found
            end
        else
            # run reqcons against values. For each requirement/constraint, check if fulfilled.
            reqcons['requirements'].each do |key, value|
                if parvals['parameters'].has_key?(key)
                    count(key, value, parvals, results)
                else # requirement not met
                    results['missing'][key] = value
                end
            end
        end
        # check the remaining values for excesss
        parvals['parameters'].each do |key, value|
            results['excess'][key] = value
        end
        reqcons['requirements'].each do |key, value|
            if results['met'].has_key?(key)
                results['missing'][key] = value - results['met'][key] if results['met'][key] < value
            end
        end
        results
    end

end


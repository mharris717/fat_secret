
class String 
  def esc 
    CGI.escape(self).gsub("%7E", "~").gsub("+", "%20")#.gsub(" ", "%20")  
  end 
end 

class Time
  def days_since_epoch
    res = to_f / (60*60*24).to_f
    res.to_i
  end
end

class Hash
  def sort_by_key
    res = {}
    keys.sort.each do |k|
      res[k] = self[k]
    end

    test = []
    res.each do |k,v|
      test << k
    end
    #puts "Sorted: " + test.join(",")

    res
  end
end

class Object
  def klass
    self.class
  end
end

def puts_pp(str)
  File.pp "debug.log",str
  File.append "debug.log","\n\n#{str.class}"
  puts str.inspect
end

class File
  def self.pp(file,obj)
    require 'pp'

    File.open(file,"w") do |f|
      PP.pp(obj,f)
    end
  end
end
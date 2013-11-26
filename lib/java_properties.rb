class JavaProperties
  def initialize
    @lines = []
  end

  def self.load(file)
    result = self.new
    result.instance_variable_set(:@lines,File.read(file).split(/\n/))
    result
  end

  def props
    @props ||= Hash[@lines.collect { |line| (line =~ /^\s*#/ or line !~ /\=/) ? nil : line.split(/\=/,2).collect(&:strip) }.compact]
  end
  
  def get(key, dereference=true)
    value = props[key].dup
    if value and dereference
      value = value.gsub(/\$\{(.+?)\}/) { |v| get($1,true) }
    end
    return value
  end

  def set(key, value)
    props[key] = value
  end

  def [](key)
    get(key, true)
  end

  def []=(key,value)
    set(key, value)
  end

  def inspect
    props.inspect
  end

  def method_missing(sym, *args, &block)
    props.send(sym, *args, &block)
  end

  def to_s
    props.each_pair do |key,value|
      prop_found = false
      @lines.each_with_index do |line,index|
        if line !~ /^\s*#/ and line =~ /\=/ and line.split(/\=/,2).first.strip == key
          @lines[index] = "#{key}=#{value}"
          prop_found = true
          break
        end
      end
      @lines << "#{key}=#{value}" unless prop_found
    end
    @lines.join("\n")
  end
end

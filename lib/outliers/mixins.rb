class Module
  def all_the_modules
    [self] + constants.map {|const| const_get(const) }
      .select {|const| const.is_a? Module }
      .flat_map {|const| const.all_the_modules }
  end
end

class Hash
  def keys_to_sym
    Hash[self.map {|k, v| [k.to_sym, v] }]
  end

  def keys_to_s
    Hash[self.map {|k, v| [k.to_s, v] }]
  end
end 

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

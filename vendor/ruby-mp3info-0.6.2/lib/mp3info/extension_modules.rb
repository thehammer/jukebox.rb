class Mp3Info 
  module HashKeys #:nodoc:
    ### lets you specify hash["key"] as hash.key
    ### this came from CodingInRuby on RubyGarden
    ### http://www.rubygarden.org/ruby?CodingInRuby
    def method_missing(meth,*args)
      m = meth.id2name
      if /=$/ =~ m
	self[m.chop] = (args.length<2 ? args[0] : args)
      else
	self[m]
      end
    end
  end

  module Mp3FileMethods #:nodoc:
    def get32bits
      (getc << 24) + (getc << 16) + (getc << 8) + getc
    end

    def get_syncsafe
      (getc << 21) + (getc << 14) + (getc << 7) + getc
    end
  end

end


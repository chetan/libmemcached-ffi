
module LibMemcachedFFI
  module FFIUtil

    class << self

      # Create a pointer to an array of values of the given type
      #
      # @param [Sybmol] type        type of values to write (e.g., ulong, size_t, etc)
      # @param [Array] arr          array of values to write
      #
      # @return [FFI::MemoryPointer] pointer to array of values
      def ptrs_of_type(type, arr)
        ptr = FFI::MemoryPointer.new(type, arr.size)
        type_obj = FFI.find_type(type)
        if not type_obj.kind_of? FFI::Type::Builtin then
          raise "#{type_obj.inspect} is not a Builtin!"
        end

        type_obj.inspect =~ /^#<FFI::Type::Builtin:(.*?) /
        method = "put_#{$1.downcase}".to_sym

        if not ptr.respond_to? method then
          raise "Can't find putter"
        end

        puts method

        arr.each_with_index do |val, i|
          offset = (i*type_obj.size)
          ptr.send(method, offset, val)
        end

        return ptr
      end

      # Create an array of String pointers
      #
      # @param [Array<String>] strings
      #
      # @return [FFI::MemoryPointer] pointer to string array
      def string_ptrs(strings)
        strings = [ strings ] if not strings.kind_of? Array
        strptrs = strings.map{ |s| FFI::MemoryPointer.from_string(s) }
        return pointer_array(strptrs)
      end


      private

      def pointer_array(pointers)
        ptrs = FFI::MemoryPointer.new(:pointer, pointers.length)
        pointers.each_with_index do |p, i|
          ptrs[i].put_pointer(0,  p)
        end

        return ptrs
      end

    end

  end # FFIUtil
end

module OpenSSL
  module PKey
    class RSA
      def initialize(string)
      end
      
      def generate()
      end
    end #RSA
  end # Pkey
  
  module Digest
    class SHA1
      # Gist from here: https://gist.github.com/925415
      @computed_hash = ""

      def self.leftrotate(value, shift)
        return ( ((value << shift) | (value >> (32 - shift))) & 0xffffffff)
      end

      def initialize(message)
        hash_words = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0] # 5.3.1

        # 5.1.1
        bit_string = message.unpack('B*').join # Unpacks message into MSB (Most Significant Bit) binary representation String
        message_length = bit_string.length
        bit_string << "1"
        bit_string = bit_string.ljust(message_length + (448 - (message_length % 512)), '0') # pad 0's until length is congruent to 448 % 512
        bit_string << message_length.to_s(2).rjust(64,'0') # binary representation of message length & pad 0's to fill 64b length
        pad_string = [bit_string].pack('B*').unpack('N*') # Pack into string from MSB Binary and then unpack into Big-endian u_int32 chunks
        # 6.1.2
        pad_string.in_groups_of(16).each do |chunk| # Split pad_string into 512b chunks (16 * 32b) -- 6.1.2 - 1. Prepare the message schedule
          #Expand from sixteen to eighty -- 6.1.2 - 1. Prepare the message schedule
          (16..79).each { |i| chunk << OpenSSL::Digest::SHA1.leftrotate((chunk[i-3] ^ chunk[i-8]  ^ chunk[i-14] ^ chunk[i-16] ), 1) }
          working_vars = Array.new(hash_words) # Copy current hash_words for next round. -- 6.1.2 - 2. Initialize the five working variables.

          for i in (0..79) do # 6.1.2 - 3. & 4.1.1 - SHA-1 Functions
            if (0 <= i && i <= 19) then
              f = ((working_vars[1] & working_vars[2]) | (~working_vars[1] & working_vars[3]))
              k = 0x5A827999
            elsif (20 <= i && i <= 39) then
              f = (working_vars[1] ^ working_vars[2] ^ working_vars[3])
              k = 0x6ED9EBA1
            elsif (40 <= i && i <= 59) then
              f = ((working_vars[1] & working_vars[2]) | (working_vars[1] & working_vars[3]) | (working_vars[2] & working_vars[3]))
              k = 0x8F1BBCDC
            elsif (60 <= i && i <= 79) then
              f = (working_vars[1] ^ working_vars[2] ^ working_vars[3])
              k = 0xCA62C1D6
            end
            # Complete round & Create array of working variables for next round.
            temp = (OpenSSL::Digest::SHA1.leftrotate(working_vars[0], 5) + f + working_vars[4] + k + (chunk[i])) & 0xffffffff
            working_vars = [temp, working_vars[0], OpenSSL::Digest::SHA1.leftrotate(working_vars[1], 30), working_vars[2], working_vars[3]]
          end

          # 6.1.2 - 4. Compute the ith intermediate hash value
          working_vars.each_with_index {|a, i| hash_words[i] = ((hash_words[i] + a) & 0xffffffff)} # append
        end

        @computed_hash = hash_words.collect {|x| x.to_s(16).rjust(8,'0')}.join
      end # End of initialize

      def to_s
        @computed_hash
      end

    end # SHA1
  end # Digest

end # OpenSSL module

# encoding: ASCII-8BIT

require 'ecdsa'
require 'digest'

class String
  def hex_inspect
    '"' + each_byte.map { |b| '\x%02x' % b }.join + '"'
  end
end

Base58Chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.split('')

def base58_decode(string)
  string.each_char.reduce(0) do |result, char|
    result * 58 + Base58Chars.index(char)
  end
end

def base58_encode(number)
  result = ''
  while number > 0
    result += Base58Chars[number % 58]
    number /= 58
  end
  result.reverse
end

def base58check_checksum(data)
  Digest::SHA256.digest(Digest::SHA256.digest(data))[0, 4]
end

def base58check_decode(string)
  bignum = base58_decode string  
  str = ECDSA::Format::IntegerOctetString.encode(bignum, 38)
  #puts "Private key stuff: " + str.hex_inspect
  version = str[0]
  payload = str[1, str.size - 5]
  if version.ord != 0x80
    raise "This doesn't look like a private key; version byte is %#x." % version.ord
  end
  checksum = base58check_checksum version + payload
  raise "Invalid checksum; data might be corrupt." if str[-4, 4] != checksum
  payload
end

def base58check_encode(version, payload)
  checksum = base58check_checksum version + payload
  data = version + payload + checksum
  leading_zero_count = data.match(/\A(\0*)/)[1].size
  '1' * leading_zero_count + base58_encode(ECDSA::Format::IntegerOctetString.decode data)
end

def private_key_decode(string)
  data = base58check_decode string
  data.force_encoding('binary')
  data = data[0, data.size - 1]
  #data.chomp!("\x01")
  #puts "Private key: " + data.hex_inspect
  #data.reverse!  # maybe needed
  raise "Expected private key to be 32 bytes." if data.size != 32
  ECDSA::Format::IntegerOctetString.decode(data)
end

def bitcoin_address(public_key, compression)
  string = ECDSA::Format::PointOctetString.encode(public_key, compression: compression)
  hash = Digest::RMD160.digest Digest::SHA256.digest string
  # Should it be "\x00", "\x01", or "\x05"?
  base58check_encode("\x00", hash)
end

def inspect_private_key(private_key)
  public_key = ECDSA::Group::Secp256k1.generator.multiply_by_scalar private_key
  p bitcoin_address public_key, true
  #p bitcoin_address public_key, false
  puts
end

# p inspect_private_key 0x18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725

ARGF.each do |line|
  next if line.match(/\A\s*#/)              # filter out comments
  match_data = line.match(/\A(\w{40,60})/)  # extract private key
  next unless match_data
  inspect_private_key private_key_decode match_data[1]
end
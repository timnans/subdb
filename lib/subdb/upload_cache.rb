# Copyright (c) 2011 Wilker Lúcio
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'digest/sha1'

class Subdb::UploadCache
  attr_reader :hash, :path

  def self.subtitle_hash(path)
    data = open(path, "rb") { |io| io.read }
    Digest::SHA1.hexdigest(data)
  end

  def initialize(path)
    if File.exists? path
      data = open(path, "rb") { |io| io.read }

      begin
        @hash = Marshal.load(data)
      rescue TypeError => e
        @hash = {}
      end
    else
      @hash = {}
    end

    @path = path
  end

  def uploaded?(hash, path)
    list = @hash[hash] || []
    list.include? self.class.subtitle_hash(path)
  end

  def push(hash, path)
    return if uploaded?(hash, path)

    @hash[hash] ||= []
    @hash[hash].push(self.class.subtitle_hash(path))
  end

  def versions(hash)
    (@hash[hash] || []).length
  end

  def store!
    File.open(path, "wb") do |file|
      file << Marshal.dump(@hash)
    end
  end
end

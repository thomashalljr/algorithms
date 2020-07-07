# Thanks to James Schroeder for all his inspiration.
# O(k^2 * n) where k=longest word, n=total words

# @param {String[]} words
# @return {Integer[][]}

class Trie
  attr_reader :root

  def initialize
    @root = TrieNode.new
  end

  def add_word(str, index)
    node = root
    str.reverse.each_char do |c|
      node = node.character_node(c)
    end
    node.index = index # handles empty strings, too
  end

  def palindromes_for_word(word)
    candidates = []
    node = root
    word.each_char.with_index do |c, idx|
      # source word is longer than trie word
      if node.index and is_palindrome?(word[idx..word.length])
        candidates << node.index
      end

      node = node.get_character_node(c)
      return candidates if node.nil?
    end

    # source word same length as trie word so it's automatically candidate
    if node.index
      candidates << node.index
    end

    # source word is shorter than trie word
    if node.has_children?
      dfs(node) do |prefix, trie_index|
        if is_palindrome?(prefix)
          candidates << trie_index
        end
      end
    end

    candidates
  end

  private

  def dfs(node, prefix="", &block)
    # found word while DFS'ing so test if it's palindrome
    yield prefix, node.index if node.index and not prefix.empty?

    node.child_map.each do |c, node|
      dfs(node, prefix+c, &block)
    end
  end
end

class TrieNode
  attr_reader   :child_map
  attr_accessor :index

  def initialize
    @child_map = {}
    @index     = nil # word if not nil
  end

  def character_node(c)
    child_map[c.downcase] ||= TrieNode.new
  end

  def get_character_node(c)
    child_map[c.downcase]
  end

  def has_children?
    not child_map.empty?
  end
end

def is_palindrome?(str)
  return true if str.length.eql? 0 or str.length.eql? 1
  str[0].eql? str[-1] and is_palindrome?(str[1..-2])
end

def palindrome_pairs(words)
  palindrome_pairs = []
  reverse_trie = Trie.new

  # build trie of reversed words
  words.each_with_index do |word, index|
    reverse_trie.add_word(word, index)
  end

  words.each_with_index do |word, index|
    candidates = reverse_trie.palindromes_for_word(word)
    candidates.each do |trie_index|
      if index != trie_index
        palindrome_pairs << [index, trie_index]
      end
    end
  end

  palindrome_pairs
end


module ParseUsers

  # @param str: a string which may include user strings like "<@U02CWFEEJ|flavri>"
  # returns an array of user IDs found in the string
  def parse_user_ids(str)
    # This regex means match <@U then 8 "word" characters (and remember the U plus 8 word chars)
    # also match the | character followed by any number word characters, then a > char.
    str.scan(/<@(U\w{8})\|\w+>/).flatten.compact
  end

  # @param str: a string which may include user strings like "<@U02CWFEEJ|flavri>"
  # returns an array of user names found in the string (without the preceding @ symbol)
  def parse_user_names(str)
    str.scan(/<@U\w{8}\|(\w+)>/).flatten.compact
  end

  class ContainsUsers
    def self.===(str)
      parse_user_ids(str).any?
    end
  end

end
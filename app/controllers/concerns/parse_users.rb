
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

  # returns a string of user names with commas between all except a penultimate "and".
  # @param user_names [array] - user names without the @ symbol
  def format_user_names(user_names)
    return "<@#{user_names.first}>" if user_names.length == 1
    user_names[0..user_names.length - 2].map {|n| "<@#{n}>"}.join(', ') + " and <@#{user_names[user_names.length - 1]}>"
  end

  # Class to use in a case statement
  # Evaluates to true if there are any user strings like "<@U02CWFEEJ|flavri>"
  # in the `case` operand.
  class ContainsUsers
    def self.===(str)
      parse_user_ids(str).any?
    end
  end

end
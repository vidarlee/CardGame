# The class of the Player
class Player
  attr_reader :position

  def initialize(position, all_cards_num, members_num, card_num_arr)
    @position = position
    @all_cards_num = all_cards_num
    @members_num = members_num
    @card_num_arr = card_num_arr.dup
    @judger = (1 << (@all_cards_num - @members_num + 1)) - 1
    @reachable_min = 1
    @reachable_max = @all_cards_num
    temp_arr = card_num_arr.dup
    temp_arr.delete_at(position)
    @unreachable_min = temp_arr.min
    @unreachable_max = temp_arr.max
    @seq_id = init_seq_id
    update_reachable_min_max
  end

  # Define a number(@seq_id) to mark which card number is valid for this player
  # et. there are 5 cards and 3 players, and @seq_id.to_s(2) = "11001"
  #   @seq_id(1 1 0 0 1)count from right side
  #   "0" means the player can't be this number
  #   "1" means the player can be this number
  #   so "11001" means the player can be 5, 4, 1, and can't be 3, 2
  def init_seq_id
    base_num = (1 << @all_cards_num) - 1
    @card_num_arr.each do |e|
      next if e == @card_num_arr[@position]
      base_num = base_num ^ (1 << (e - 1))
    end
    base_num
  end

  # Update the mininum and maximum number which the player can be
  def update_reachable_min_max
    max_flag = true
    min_flag = true
    @all_cards_num.downto(1) do |i|
      if (@seq_id & (1 << i - 1)) > 0 && max_flag
        max_flag = false
        @reachable_max = i
      end
      if (@seq_id & (1 << @all_cards_num - i)) > 0 && min_flag
        min_flag = false
        @reachable_min = @all_cards_num - i + 1
      end
      return unless max_flag || min_flag
    end
  end

  def answer
    return 'mid' if @reachable_min > @unreachable_min &&
                    @reachable_max < @unreachable_max
    return 'max' if @reachable_min > @unreachable_max
    return 'min' if @reachable_max < @unreachable_min
    nil
  end

  # The player(position) can't get answer, then determine which number can't be
  def update_seq_id(position)
    temp_seq_id = @seq_id | (1 << @card_num_arr[position] - 1)
    temp_judger = @judger
    (0..(@members_num - 1)).each do |ee|
      tt_judger = temp_judger << ee
      if (temp_seq_id & tt_judger) == tt_judger &&
         (temp_seq_id ^ tt_judger) != (1 << @card_num_arr[position] - 1)
        # Can't be this number, otherwise the player can determine
        @seq_id = @seq_id ^ (temp_seq_id ^ tt_judger)
        @judger = @judger >> 1
      end
    end

    if @unreachable_max == @all_cards_num && @card_num_arr[position] \
       != @all_cards_num && @reachable_min < @unreachable_min
      # Can't be this reachable min, otherwise the play can determine mid
      @seq_id = @seq_id ^ (1 << @reachable_min - 1)
      @judger = @judger >> 1
    end

    if @unreachable_min == 1 && @card_num_arr[position] != 1 &&
       @reachable_max > @unreachable_max
      # Can't be this reachable max, otherwise the play can determine mid
      @seq_id = @seq_id ^ (1 << @reachable_max - 1)
      @judger = @judger >> 1
    end

    update_reachable_min_max
  end

  private :init_seq_id, :update_reachable_min_max
end

class Cardgame
  def initialize(all_cards_num, card_num_arr)
    @all_cards_num = all_cards_num
    @members_num = card_num_arr.size
    @card_num_arr = card_num_arr
    @name_of_members = ('A'..'Z').to_a[0..@members_num - 1]
    @player_arr = []
    init_game
  end

  def init_game
    if params_invalid
      # raise "Input is invalid, please check and run again"
      return
    end
    @members_num.times do |e|
      @player_arr << Player.new(e, @all_cards_num, @members_num, @card_num_arr)
    end
  end

  def params_invalid
    @card_num_arr.sort[-1] > @all_cards_num || @card_num_arr.sort[0] < 1 ||
      @members_num > @all_cards_num ||
      @card_num_arr.uniq.size < @card_num_arr.size
  end

  def solution
    if params_invalid
      puts 'Input is invalid, please check and run again'
      return
    end
    res_arr = []
    loop do
      @player_arr.each do |p|
        res = p.answer
        if res
          res_arr << "#{@name_of_members[p.position]} => #{res}"
          puts res_arr.to_s
          return
        else
          @player_arr.each do |pp|
            pp.update_seq_id(p.position) if p != pp
          end
        end
        res_arr << "#{@name_of_members[p.position]} => ?"    
      end
    end
  end
end


# For test

Cardgame.new(5, [1, 3, 5]).solution
Cardgame.new(5, [1, 4, 5]).solution
Cardgame.new(5, [1, 2, 4]).solution
Cardgame.new(5, [2, 3, 4]).solution
Cardgame.new(7, [2, 4, 6]).solution
Cardgame.new(7, [2, 5, 6]).solution
Cardgame.new(7, [2, 5, 4]).solution
Cardgame.new(8, [2, 6, 4]).solution
Cardgame.new(8, [2, 4, 6]).solution
Cardgame.new(7, [1, 2, 5, 6]).solution
Cardgame.new(5, [3, 1, 5, 2]).solution
Cardgame.new(5, [1, 5, 2, 4]).solution
Cardgame.new(6, [1, 2, 3, 6]).solution
Cardgame.new(6, [1, 3, 4, 5]).solution
Cardgame.new(5, [1, 5, 2, 4, 3]).solution
Cardgame.new(18, [2, 6, 11]).solution
Cardgame.new(18, [2, 6, 1, 16]).solution
Cardgame.new(10, [2, 6, 11]).solution
Cardgame.new(0, [2, 6, 11]).solution
Cardgame.new(18, [2, 0, 11]).solution
# Cardgame.new(7, [3, 5]).solution  #no answer
# Cardgame.new(9, [2, 4, 6, 8]).solution #no answer

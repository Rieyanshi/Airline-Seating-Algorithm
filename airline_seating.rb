# require 'pry'
require 'json'

class AirlineSeating
  attr_accessor :passengers_seats, :seatCount, :passengers, :status

  def initialize(*args)
    @status = constraint_check(args)
    if @status.nil?
      @seatCount = @seats_available.inject(0) { |sum, x| sum += x[0] * x[1] }
      @passengers_seats = true if @seatCount < @passengers
      @max_columns = @seats_available.map(&:last).max
      @Completion_count = 0
    end
  end

  def arrangement
    array_formation
    aisle_seat_completion
    window_seat_completion
    center_seat_completion
  end

  def constraint_check(args)
    return "Enter 2D array and number of passenger as input!" if args.flatten.map(&:strip).reject(&:empty?).empty?
    return "Enter 2D array" if args.flatten[0].strip.empty?
    return "Enter Number of passengers" if args.flatten[1].nil? || args.flatten[1].strip.empty?
    begin
      @seats_available = JSON.parse(args.flatten[0])
    rescue
      return "Array formating issue: Array is not entered correctly"
    end
    return "Please enter 2D format array" unless @seats_available.all? { |x| x.is_a?(Array) }
    return "Subarray entered are not valid" unless @seats_available.all? { |x| x.size == 2 }
    return "Values entered in array are incorrect" if @seats_available.any? { |x| x.any?(0) }
    begin
      @passengers = JSON.parse(args.flatten[1])
    rescue
      return "No. of passenger is not correct: please enter a valid integer"
    end
    return "Ener a positive integer only" unless @passengers.is_a?(Integer)
  end

  private

  def array_formation
    @empty_seat = @seats_available.each_with_object([]).with_index do |(arr, seats), index|
      seats << (1..arr[1]).map { |x| Array.new(arr[0]) { 'N' } }
    end
    @sorted_seats = (1..@max_columns).each_with_object([]).with_index do |(x, arr), index|
      arr << @empty_seat.map { |x| x[index] }
    end
  end

  def aisle_seat_completion
    @corner seats = @sorted_seats.each_with_object([]) do |elem_array, res_array|
      res_array << if elem_array.nil?
        nil
      else
        elem_array.each_with_object([]).with_index do |(sitting_arrangement, update_arr), index|
          update_arr << if sitting_arrangement.nil?
            nil
          else
            if index == 0
              @Completion_count += 1
              sitting_arrangement[-1] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
            elsif index == elem_array.size - 1
              unless sitting_arrangement.size == 1
                @Completion_count += 1
                sitting_arrangement[0] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
              end
            else
              @Completion_count += 1
              sitting_arrangement[0] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
              unless sitting_arrangement.size == 1
                @Completion_count += 1
                sitting_arrangement[-1] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
              end
            end
            sitting_arrangement
          end
        end
      end
    end
  end

  def window_seat_completion
    @window_seats = @corner seats.each_with_object([]) do |elem_array, res_array|
      res_array << if elem_array.nil?
        nil
      else
        elem_array.each_with_object([]).with_index do |(sitting_arrangement, update_arr), index|
          update_arr << if sitting_arrangement.nil?
            nil
          else
            if index == 0
              @Completion_count += 1
              sitting_arrangement[0] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
            elsif index == elem_array.size - 1
              @Completion_count += 1
              sitting_arrangement[-1] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
            end
            sitting_arrangement
          end
        end
      end
    end
  end

  def center_seat_completion
    @center_seats = @window_seats.each_with_object([]) do |elem_array, res_array|
      res_array << if elem_array.nil?
        nil
      else
        elem_array.each_with_object([]).with_index do |(sitting_arrangement, update_arr), index|
          update_arr << if sitting_arrangement.nil?
            nil
          else
            if sitting_arrangement.size > 2
              (1..sitting_arrangement.size - 2).each do |x|
                @Completion_count += 1
                sitting_arrangement[x] = @Completion_count <= @passengers ? @Completion_count.to_s.rjust(@seatCount.to_s.size, "0") : 'X'*@seatCount.to_s.size
              end
            end
            sitting_arrangement
          end
        end
      end
    end
  end
end

lines = File.readlines('input.txt')
# puts "Enter 2D array: "
# array_ip = gets.chomp
# puts "Enter the number of passengers: "
# pass_count = gets.chomp
# seating = AirlineSeating.new(array_ip, pass_count)
seating = AirlineSeating.new(lines)
if seating.status.nil?
  puts "Number of seats are less than passenger count : #{seating.passengers} .\
   Only #{seating.seatCount} seats are available!" if seating.passengers_seats
  result = seating.arrangement
  File.open("output.txt", "w") do |file|
    result.each_with_index do |row, parent_index|
      row_formatted = ''
      row.each_with_index do |arr, index|
        if index == row.size - 1
          print_value = arr.inspect.gsub(',', '').gsub('"', '')
        else
          print_value = arr.inspect.gsub(',', '').gsub('"', '') + ' '
        end
        if parent_index == 0
          instance_variable_set("@arr_length_#{index}", print_value.length)
        else
          print_value = " " * instance_variable_get("@arr_length_#{index}").to_i if print_value.strip == 'nil'
        end
        row_formatted += print_value
      end
      file.write("#{row_formatted}\n")
    end
  end
else
  puts seating.status
end

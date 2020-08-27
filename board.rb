class Board
  CELL_MAPPING = {
    nil => 'o',
    :white => 'w',
    :black => 'b',
    true => 'x'
  }.freeze
  ROW_SEPERATOR = {
    0 => "|\|/|",
    1 => "|/|\|"
  }.freeze

  def initialize
    @grid = (1..3).map { [nil, nil, nil] }
  end

  def place(x, y)
    grid[x - 1][y - 1] = true
  end

  def layout
    layout =[]
    grid.map.with_index do |row, i|
      layout << row.map do |cell|
        CELL_MAPPING[cell]
      end.join("-")
      layout << ROW_SEPERATOR[i] if ROW_SEPERATOR[i]
    end
    layout.join("\n")
  end

  def move(from_pair, to_pair)
    fx, fy = from_pair
    tx, ty = to_pair
    grid[fx - 1][fy - 1] = nil
    grid[tx - 1][ty - 1] = true
  end

  private
  attr_reader :grid
end

class Client
  attr_reader :name

  def initialize(buffer: $stdin)
    @buffer = buffer
    @inputs = []
  end

  def ask_to_place
    inputs << buffer.gets.chomp
  end

  def ask_to_move
    inputs << buffer.gets.chomp
  end

  def ask_for_name
    inputs << buffer.gets.chomp
    @name = last_input
  end

  def last_input
    inputs.last
  end

  private
  attr_reader :buffer, :inputs
end

class Game
  attr_reader :output

  def initialize(buffer: $stdin)
    @output = []
    @player_1 = Client.new(buffer: buffer)
    @player_2 = Client.new(buffer: buffer)
  end

  def start
    say("Player 1 please enter your name: ")
    player_1.ask_for_name
    say("Player 2 please enter your name: ")
    player_2.ask_for_name
    say("#{player_1.name} goes first, place your first piece: ")
  end

  private

  attr_reader :player_1, :player_2
  def say(text)
    output << text
    print text
  end
end

require 'rspec'

RSpec.describe Game do
  it 'allow players to enter their names' do
    buffer = StringIO.new
    game = Game.new(buffer: buffer)
    buffer.puts("Bob")
    buffer.puts("Alice")
    buffer.rewind
    game.start
    expect(game.output).to eq([
      %Q(Player 1 please enter your name: ),
      %Q(Player 2 please enter your name: ),
      %Q(Bob goes first, place your first piece: )
    ])
  end
end

RSpec.describe Board do
  subject(:board) { described_class.new }

  it 'allows to place piece in specific coordinates' do
    board.place(2, 2)
    expect(board.layout).to eq(
%Q(o-o-o
|\|/|
o-x-o
|/|\|
o-o-o))
  end

  it 'allows to move piece from coordinate to coordinate' do
    board.place(2, 2)
    board.move([2, 2], [1, 3])
        expect(board.layout).to eq(
%Q(o-o-x
|\|/|
o-o-o
|/|\|
o-o-o))
  end
end

RSpec.describe Client do
  subject(:cli) { described_class.new(buffer: buffer) }
  let(:buffer) { StringIO.new }

  it 'asks to place a piece' do
    buffer.puts("12")
    buffer.rewind
    cli.ask_to_place
    expect(cli.last_input).to eq('12')
  end

  it 'asks to move a piece' do
    buffer.puts('12 22')
    buffer.rewind
    cli.ask_to_move
    expect(cli.last_input).to eq('12 22')
  end

  it "asks for player's name" do
    buffer.puts('Bob')
    buffer.rewind
    cli.ask_for_name
    expect(cli.last_input).to eq('Bob')
    expect(cli.name).to eq('Bob')
  end
end

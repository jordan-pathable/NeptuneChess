class Path < ActiveRecord::Base
  belongs_to :move
  has_many :coordinates, dependent: :destroy

  def primary_path
    # First coordinate in the path is the move source   
    self.coordinates.create.from_chess_coord(self.move.source).save

    unless self.move.piece == 'n'
      self.coordinates.create.from_chess_coord(self.move.target).save
    else
      x = Coordinate.new.from_chess_coord(self.move.source).x
      y = Coordinate.new.from_chess_coord(self.move.source).y 

      # Half-step diagonal
      x = x + (Coordinate.new.from_chess_coord(self.move.target).x <=> x)
      y = y + (Coordinate.new.from_chess_coord(self.move.target).y <=> y)
      self.coordinates.create(:x => x, :y => y).save

      # Full step on the long side
      x_movement = Coordinate.new.from_chess_coord(self.move.target).x - Coordinate.new.from_chess_coord(self.move.source).x
      y_movement = Coordinate.new.from_chess_coord(self.move.target).y - Coordinate.new.from_chess_coord(self.move.source).y
      x = x + (2 * (x_movement > y_movement ? 1 : 0) * (Coordinate.new.from_chess_coord(self.move.target).x <=> x))
      y = y + (2 * (x_movement > y_movement ? 0 : 1) * (Coordinate.new.from_chess_coord(self.move.target).y <=> y))
      self.coordinates.create(:x => x, :y => y).save

      # Half-step diagonal
      x = x + (Coordinate.new.from_chess_coord(self.move.target).x <=> x)
      y = y + (Coordinate.new.from_chess_coord(self.move.target).y <=> y)
      self.coordinate.create(:x => x, :y => y).save
    end

    self.update_nodes
  end

  def remove_captured
    captured = Coordinate.new.from_chess_coord(self.move.target)

    # Check for en passant
    if self.move.flag == 'e'
      captured.y = captured.y + (2 * (is_white(captured) ? -1 : 1))
    end

    x = captured.x
    y = captured.y

    # First coordinate in the path is the location of the piece being taken
    self.coordinates.create(:x => x, :y => y)

    # Find an empty parking space
    parking_spots = is_white(captured) ? Coordinate.new.parking[:white] : Coordinate.new.parking[:black]

    i = 0
    while !(Node.find_by_x_and_y(parking_spots[i][:x], parking_spots[i][:y]).occupant.blank?)
      i = i +1
    end
    parking_target = Coordinate.new(:x => parking_spots[i][:x], :y => parking_spots[i][:y])

    # Move half-step towards the center
    y = 1 - (y <=> 4.5)
    self.coordinates.create(:x => x, :y => y)

    # Move to left edge if piece taken is white, right edge if black
    x = parking_target.x + (parking_target.x <=> x)
    self.coordinates.create(:x => x, :y => y)

    y = parking_target.y
    self.coordinates.create(:x => x, :y => y)

    self.coordinates.create(:x => parking_target.x, :y => y)

    self.update_nodes
  end

  def castling
    y = is_white(self.coordinates.new(self.move.target)) ? 0 : 14
    x = self.move.flag == 'q' ? 4 : 18
    self.coordinates.create(:x => x, :y => y)

    y = y + (y == 0 ? 1 : -1)
    self.coordinates.create(:x => x, :y => y)

    x = x + self.move.flag == 'q' ? 6 : 4
    self.coordinates.create(:x => x, :y => y)

    y = y + (y == 1 ? -1 : 1)
    self.coordinates.create(:x => x, :y => y)

    self.update_nodes
  end

  def promotion
    # TODO
    self.update_nodes
  end

  def update_nodes
    source = Node.find_by_x_and_y(self.coordinates[0].x, self.coordinates[0].y)

    destination = Node.find_by_x_and_y(self.coordinates[self.coordinates.length - 1].x, self.coordinates[self.coordinates.length - 1].y)

    destination.update_attribute(:occupant, source.occupant)
    source.update_attribute(:occupant, "")
  end

  private
  def is_white(c)
    return !(/PNBRQK/.match(Node.find_by_x_and_y(c.x,c.y).occupant).blank?)
  end
end
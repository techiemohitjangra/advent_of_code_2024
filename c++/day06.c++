#include <cstdint>
#include <exception>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

using std::cout;
using std::endl;
using std::string;
using std::vector;

std::vector<std::string_view> splitStringView(const std::string &input,
                                              char delimiter = '\n') {
    std::vector<std::string_view> result;
    size_t start = 0;
    size_t end;
    while ((end = input.find(delimiter, start)) != std::string::npos) {
        result.emplace_back(input.data() + start, end - start);
        start = end + 1;
    }
    if (start < input.size()) {
        result.emplace_back(input.data() + start, input.size() - start);
    }
    return result;
}

enum CellState {
    Guard,
    Empty,
    Obstacle,
};

struct Position {
    uint16_t y;
    uint16_t x;

    bool operator==(const Position &other) const {
        return y == other.y && x == other.x;
    }
};

struct PositionHash {
    std::size_t operator()(const Position &pos) const {
        return std::hash<int>()(pos.y) ^ (std::hash<int>()(pos.x) << 1);
    }
};

enum Direction {
    Up = 0,
    Right,
    Down,
    Left,
};

struct DirectionOffset {
    int8_t dy;
    int8_t dx;
};

DirectionOffset DirectionOffsets[] = {
    DirectionOffset{.dy = -1, .dx = 0},
    DirectionOffset{.dy = 0, .dx = 1},
    DirectionOffset{.dy = 1, .dx = 0},
    DirectionOffset{.dy = 0, .dx = -1},
};

class PuzzleExceptions : public std::exception {
    string message;

  public:
    explicit PuzzleExceptions(const std::string &msg) : message(msg) {}
    const char *what() const noexcept override { return message.c_str(); }
};

class Puzzle {
    vector<vector<CellState>> map;
    Direction direction;
    Position start;
    Position current;
    Position next;

  public:
    Puzzle(string filename) {
        string data = this->read_data(filename);
        vector<std::string_view> lines = splitStringView(data);
        this->map = this->parse_map(lines);
        this->start = this->get_start_position();
        this->current = this->start;
        this->next.y = this->current.y + DirectionOffsets[this->direction].dy;
        this->next.x = this->current.x + DirectionOffsets[this->direction].dx;
    }

    void rotate() {
        switch (this->direction) {
        case Up:
            this->direction = Right;
            break;
        case Right:
            this->direction = Down;
            break;
        case Down:
            this->direction = Left;
            break;
        case Left:
            this->direction = Up;
            break;
        }
        this->next.y = this->current.y + DirectionOffsets[this->direction].dy;
        this->next.x = this->current.x + DirectionOffsets[this->direction].dx;
    }

    void move() {
        this->map[this->current.y][this->current.x] = Empty;
        this->current.y = this->next.y;
        this->current.x = this->next.x;
        this->map[this->current.y][this->current.x] = Guard;
        this->next.y = this->current.y + DirectionOffsets[this->direction].dy;
        this->next.x = this->current.x + DirectionOffsets[this->direction].dx;
    }

    string read_data(string filename) {
        std::ifstream file(filename, std::ifstream::in);
        auto size = std::filesystem::file_size(filename);
        char *buffer = new char[size];
        file.read(buffer, size);
        std::string data(buffer);
        delete[] buffer;
        return data;
    }

    Position get_start_position() {
        uint16_t y = 0;
        for (const vector<CellState> &row : this->map) {
            uint16_t x = 0;
            for (const CellState &cell : row) {
                if (cell == Guard) {
                    return Position{
                        .y = y,
                        .x = x,
                    };
                }
                ++x;
            }
            ++y;
        }
        throw PuzzleExceptions("Guard not found\n");
    }

    vector<vector<CellState>> parse_map(vector<std::string_view> lines) {
        vector<vector<CellState>> res;
        for (const std::string_view &line : lines) {
            vector<CellState> row;
            for (const char &character : line) {
                switch (character) {
                case '.':
                    row.push_back(Empty);
                    break;
                case '^':
                    row.push_back(Guard);
                    this->direction = Up;
                    break;
                case '>':
                    row.push_back(Guard);
                    this->direction = Right;
                    break;
                case 'v':
                    row.push_back(Guard);
                    this->direction = Down;
                    break;
                case '<':
                    row.push_back(Guard);
                    this->direction = Left;
                    break;
                case '#':
                    row.push_back(Obstacle);
                    break;
                default:
                    throw PuzzleExceptions("Invalid character\n");
                }
            }
            res.push_back(row);
        }
        return res;
    }

    void print() {
        for (const vector<CellState> &row : this->map) {
            for (const CellState &cell : row) {
                switch (cell) {
                case Guard:
                    switch (this->direction) {
                    case Up:
                        std::cout << "^";
                        break;
                    case Right:
                        std::cout << ">";
                        break;
                    case Down:
                        std::cout << "v";
                        break;
                    case Left:
                        std::cout << "<";
                        break;
                    };
                    break;
                case Empty:
                    std::cout << ".";
                    break;
                case Obstacle:
                    std::cout << "#";
                    break;
                }
            }
            std::cout << std::endl;
        }
    }

    void reset() {
        this->map[this->current.y][this->current.x] = Empty;
        this->current = this->start;
        this->map[this->current.y][this->current.x] = Guard;
        this->direction = Up;
        this->next.y = this->current.y + DirectionOffsets[this->direction].dy;
        this->next.x = this->current.x + DirectionOffsets[this->direction].dx;
    }

    // alternate way to find visited positions; moved the put into visited map
    std::unordered_map<Position, Direction, PositionHash> visited_position() {
        std::unordered_map<Position, Direction, PositionHash> visited;
        while (this->next.y >= 0 && this->next.y < this->map.size() &&
               this->next.x >= 0 && this->next.x < this->map[0].size()) {
            if (this->map[this->next.y][this->next.x] == Obstacle) {
                this->rotate();
                continue;
            }
            visited[this->current] = this->direction;
            this->move();
        }
        visited[this->current] = this->direction;
        return visited;
    }

    size_t part1() {
        std::unordered_map<Position, Direction, PositionHash> visited =
            this->visited_position();
        return visited.size();
    }

    bool has_loop() {
        std::unordered_map<Position, Direction, PositionHash> visited;
        while (this->next.y >= 0 && this->next.y < this->map.size() &&
               this->next.x >= 0 && this->next.x < this->map[0].size()) {
            if (visited.find(this->current) != visited.end() &&
                visited[this->current] == this->direction) {
                return true;
            }
            if (this->map[this->next.y][this->next.x] == Obstacle) {
                this->rotate();
                continue;
            }
            visited[this->current] = this->direction;
            this->move();
        }
        return false;
    }

    size_t part2() {
        size_t res = 0;
        auto visited = visited_position();
        for (const std::pair<Position, Direction> pos : visited) {
            this->reset();
            if (pos.first.x == this->start.x && pos.first.y == this->start.y) {
                continue;
            }
            this->map[pos.first.y][pos.first.x] = Obstacle;
            if (has_loop()) {
                res += 1;
            }
            this->map[pos.first.y][pos.first.x] = Empty;
        }
        return res;
    }
};

int main() {
    // std::string filename = "../tests/day06.test";
    std::string filename = "../inputs/day06.input";
    Puzzle p = Puzzle(filename);
    std::cout << p.part1() << std::endl;
    p.reset();
    std::cout << p.part2() << std::endl;
    return 0;
}

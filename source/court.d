module court;

class Court
{
  private:
    int _width;
    int _height;

  public:
    this(int width = 1024, int height = 768)
    {
      _width = width;
      _height = height;
    }

    int width() { return _width; }
    int height() { return _height; }
}

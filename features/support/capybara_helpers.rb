module CapybaraHelpers
  def pause
    STDIN.getc
  end

  def mini_sleep
    sleep 0.1
  end
end

World(::CapybaraHelpers)
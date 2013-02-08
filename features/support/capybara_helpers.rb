module CapybaraHelpers
  def pause
    STDIN.getc
  end

  def mini_sleep
    sleep 0.1
  end

  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end

World(::CapybaraHelpers)

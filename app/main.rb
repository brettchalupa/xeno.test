TRUE_BLACK = { r: 0, g: 0, b: 0 }
WHITE = { r: 255, g: 255, b: 255 }

# Access in code with `SPATHS[:my_sprite]`
# Replace with your sprites!
SPATHS = {
  my_sprite: "sprites/my_sprite.png",
}

def debug?
  !!$gtk.production
end

CONFIRM_KEYS = [:j, :z, :enter, :space]
def confirm?(inputs)
  inputs.controller_one.key_down&.a ||
    (CONFIRM_KEYS & inputs.keyboard.keys[:down]).any?
end

INTRO = :intro
AUDIT = :audit

INTRO_TEXT = [
  "OFFICER: We've had reports of anthros in the area.",
  "OFFICER: Step up the terminal. You have nothing to worry about.",
]
def tick_intro(args)
  args.state.intro_index ||= 0

  if confirm?(args.inputs)
    args.state.intro_index += 1
  end

  if (args.state.intro_index >= INTRO_TEXT.length)
    args.state.scene = AUDIT
  end

  args.outputs.labels << { x: 120, y: 120, text: INTRO_TEXT[args.state.intro_index] }.merge(WHITE)
end

def tick_audit(args)
  args.outputs.labels << { x: 120, y: 120, text: "Audit" }.merge(WHITE)
end

def tick(args)
  args.outputs.background_color = TRUE_BLACK.values
  args.state.scene ||= INTRO

  send("tick_#{args.state.scene}", args)

  debug_tick(args)
end

def debug_tick(args)
  return unless debug?

  args.outputs.debug << [args.grid.w - 12, args.grid.h, "#{args.gtk.current_framerate.round}", 0, 1, *WHITE.values].label

  if args.inputs.keyboard.key_up.i
    SPATHS.each { |_, v| args.gtk.reset_sprite(v) }
    args.gtk.notify!("Sprites reloaded")
  end

  if args.inputs.keyboard.key_up.r
    $gtk.reset
  end
end

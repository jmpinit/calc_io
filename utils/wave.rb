case ARGV[0]
when "sin"
	@wave = lambda {|t| (Math.sin(t*Math::PI/128)*128+128).to_i }
when "noise"
	@wave = lambda {|t| rand(255)}
end

num = 0
(0..255).step(2) { |v|
	a = @wave.call v
	b = @wave.call v+1
	puts ".db #{a}, #{b} ;#{num}"
	num += 1
}

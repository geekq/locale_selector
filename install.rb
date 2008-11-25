puts IO.read(File.join(File.dirname(__FILE__), 'README'))
gg = GettextHacksGenerator.new([[], {:collision=>:ask, :quiet=>false, :generator=>"gettext_hacks", :command=>:create}])
gg.command(:create).invoke!

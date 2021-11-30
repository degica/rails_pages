RailsPages::Page.define('/testpage') do
  authorize { true }

  data do
    { hello: 'world' }
  end
end

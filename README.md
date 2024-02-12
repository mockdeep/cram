# Cram

Cram is a simple flash card app. It cycles through cards and quizzes you. It
optimizes for reviewing the cards you're having the most trouble with, and
having occasional review of cards that you've gone through. If you manage to
get through all of the cards in your deck, it will bump up the standards, until
you're able to consistently answer correctly.

## Installation

For now you'll need to `git clone` the repo and run within the repo directory.

## Usage

First you need to set up a deck to work from. There is an import tool you can
make use of, `Cram::Actions::Import`. You'll find example scripts in the
`examples/` directory. The importer will store the formatted deck in your home
directory under `~/.cram/decks/`. Cram stores metadata about your progress
inside this file once you start learning, so don't replace it unless you're
okay losing your progress. We'll probably eventually provide a way to add to an
existing deck without losing your stats.

Once you have a deck, you can run `exe/cram` to select it and begin practicing.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org][rg].

## Contributing

Bug reports and pull requests are welcome on [the GitHub repo][rep]. This
project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [code of conduct][coc].

## License

The gem is available as open source under the terms of the [MIT License][mit].

## Code of Conduct

Everyone interacting in the Cram project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct][coc].

[rg]: https://rubygems.org
[rep]: git@github.com:mockdeep/cram.git
[coc]: https://github.com/[USERNAME]/cram/blob/main/CODE_OF_CONDUCT.md
[mit]: https://opensource.org/licenses/MIT


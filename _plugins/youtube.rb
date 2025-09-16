module Jekyll
  class YouTubeTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @video_id = text.strip
    end

    def render(context)
      <<~HTML
        <iframe width="560" height="315"
          src="https://www.youtube.com/embed/#{@video_id}"
          frameborder="0" allowfullscreen>
        </iframe>
      HTML
    end
  end
end

Liquid::Template.register_tag('youtube', Jekyll::YouTubeTag)

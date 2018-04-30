module OSA
  module Extensions
    module String
      # Colors
      def red; colorize(self, "\e[1m\e[31m"); end
      def green; colorize(self, "\e[1m\e[32m"); end
      def dark_green; colorize(self, "\e[32m"); end
      def yellow; colorize(self, "\e[1m\e[33m"); end
      def blue; colorize(self, "\e[1m\e[34m"); end
      def dark_blue; colorize(self, "\e[34m"); end
      def purple; colorize(self, "\e[35m"); end
      def dark_purple; colorize(self, "\e[1;35m"); end
      def cyan; colorize(self, "\e[1;36m"); end
      def dark_cyan; colorize(self, "\e[36m"); end
      def pure; colorize(self, "\e[0m\e[28m"); end
      def underline; colorize(self, "\e[4m"); end
      def bold; colorize(self, "\e[1m"); end
      def reset; colorize(self, "\e[0m\e[28m"); end
      def colorize(text, color_code) "#{color_code}#{text}\e[0m" end

      # Cursor
      def mv_down(n=1) cursor(self, "\033[#{n}B") end
      def cls_upline; cursor(self, "\e[K") end
      def cursor(text, position)"\r#{position}#{text}" end
    end
  end
end
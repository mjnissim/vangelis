module OutingsHelper
  def report_placeholder_text
    s = "Puts each street and its block numbers on a new line:
    <br><br>
    Hertzl 45, 46, 50-58 <br>
    Sokolov 1-10, 15, 43
    <br><br>
    Can do even or odd numbers:
    <br><br>
    Weizmann 20-40 even, 40-50 odd"
    
    s.html_safe
  end
end

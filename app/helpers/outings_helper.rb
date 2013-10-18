module OutingsHelper
  def report_placeholder_text
    s = "<b>Put each street and its block numbers on a new line:</b>
    <br /><br />
    Hertzl 45, 46, 50-58 <br />
    Sokolov 1-10, 15, 43
    <br /><br />
    <b>Can do 'odd' and 'even' numbers as well:</b>
    <br /><br />
    Weizmann 20-40 even, 40-50 odd
    <br /><br />
    <b>Cannot do numbers with letters or slashes, like 21/8b:</b>
    <br /><br />
    Diezengof 15/8 <= not good <br />
    Habonim 6b <= not good"
    
    s.html_safe
  end
end

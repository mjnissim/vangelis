# THIS IS INTENDED ONLY TO MAKE BUILDINGS::CONCISESTRING WORK WITH 
# NUMBERS AS WELL AS BUILDINGS. IT WAS A QUICK WORKAROUND.
class Fixnum
  def address() self end
  def number() self end
  def flats?() end
  def entrance?() end
  def partially_marked?() end
end
  
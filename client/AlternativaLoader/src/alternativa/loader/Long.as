package alternativa.loader
{
    public class Long
    {
        public var high:int;
        public var low:int;

        public function Long(high:int, low:int)
        {
            this.high = high;
            this.low = low;
        }

        public function toString() : String
        {
            return "Long(" + this.high + ", " + this.low + ")";
        }
    }
}
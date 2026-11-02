using restoren_app.Data.Models;

namespace restoren_app.Rules
{
    // One line the customer sends: product id + quantity
    public record OrderLine(int ProductId, int Quantity);

    // Order math. Only the server calculates totals; we never accept a price from the frontend.
    public static class OrderCalculator
    {
        public const int MinQuantity = 1;
        public const int MaxQuantity = 50;

        // If the same product is sent twice, join them into one line and add the quantities
        public static List<OrderLine> MergeLines(List<OrderLine> lines)
        {
            // key = product id, value = total quantity
            var quantities = new Dictionary<int, int>();

            foreach (var line in lines)
            {
                if (quantities.ContainsKey(line.ProductId))
                    quantities[line.ProductId] += line.Quantity;
                else
                    quantities[line.ProductId] = line.Quantity;
            }

            var merged = new List<OrderLine>();
            foreach (var pair in quantities)
                merged.Add(new OrderLine(pair.Key, pair.Value));

            return merged;
        }

        // Line total = price x quantity
        public static decimal LineTotal(decimal unitPrice, int quantity)
        {
            return unitPrice * quantity;
        }

        // Order total = sum of all line totals
        public static decimal CalculateTotal(List<OrderItem> items)
        {
            decimal total = 0;
            foreach (var item in items)
                total += LineTotal(item.UnitPrice, item.Quantity);

            return total;
        }

        // Checks the quantity is between 1 and 50
        public static bool IsValidQuantity(int quantity)
        {
            return quantity >= MinQuantity && quantity <= MaxQuantity;
        }
    }
}

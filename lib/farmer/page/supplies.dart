import 'package:flutter/material.dart';

class SuppliesHistoryPage extends StatelessWidget {
  final List<Map<String, String>> suppliesHistory = [
    {
      "date": "2024-06-10",
      "milkQuantity": "20 Liters",
      "amountPaid": "\$50",
      "status": "Paid",
    },
    {
      "date": "2024-06-09",
      "milkQuantity": "18 Liters",
      "amountPaid": "\$45",
      "status": "Pending",
    },
    {
      "date": "2024-06-08",
      "milkQuantity": "25 Liters",
      "amountPaid": "\$62",
      "status": "Paid",
    },
    {
      "date": "2024-06-07",
      "milkQuantity": "22 Liters",
      "amountPaid": "\$55",
      "status": "Paid",
    },
    {
      "date": "2024-06-06",
      "milkQuantity": "19 Liters",
      "amountPaid": "\$48",
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Supplies History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: suppliesHistory.length,
          itemBuilder: (context, index) {
            final supply = suppliesHistory[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supply Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date: ${supply['date']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Chip(
                          label: Text(
                            supply['status']!,
                            style: TextStyle(
                              color: supply['status'] == "Paid"
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          backgroundColor: supply['status'] == "Paid"
                              ? Colors.blue
                              : Colors.orangeAccent,
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    SizedBox(height: 6),

                    // Milk Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Milk Quantity:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          supply['milkQuantity']!,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),

                    // Amount Paid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount Paid:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          supply['amountPaid']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

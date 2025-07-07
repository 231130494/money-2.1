// lib/view/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money/controller/transaction_provider.dart';
import 'package:money/services/exchange_rate_service.dart'; 
import 'package:money/view/transaction_list_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExchangeRateService _exchangeRateService = ExchangeRateService();
  double? _usdExchangeRate;
  bool _isLoadingExchangeRate = false;
  String? _exchangeRateError;
  bool _showUsdBalance = false;
  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    setState(() {
      _isLoadingExchangeRate = true;
      _exchangeRateError = null;
    });
    try {
      final rate = await _exchangeRateService.fetchExchangeRate('USD');
      setState(() {
        _usdExchangeRate = rate;
      });
    } catch (e) {
      setState(() {
        _exchangeRateError = 'Gagal memuat kurs mata uang: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingExchangeRate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currencyFormatIdr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final currencyFormatUsd = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');
    double? usdBalance;
    double? usdTotalIncome;
    double? usdTotalExpense;

    if (_usdExchangeRate != null && _usdExchangeRate! > 0) {
      usdBalance = transactionProvider.balance * _usdExchangeRate!;
      usdTotalIncome = transactionProvider.totalIncome * _usdExchangeRate!;
      usdTotalExpense = transactionProvider.totalExpense * _usdExchangeRate!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CJLS Wallet Dashboard'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await transactionProvider.fetchTransactions();
          await _fetchExchangeRate();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector( 
                  onTap: () {
                    setState(() {
                      _showUsdBalance = !_showUsdBalance;
                    });
                  },
                  child: _buildBalanceCard(
                    'Saldo Anda',
                    _showUsdBalance && usdBalance != null
                        ? currencyFormatUsd.format(usdBalance)
                        : currencyFormatIdr.format(transactionProvider.balance),
                    Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector( 
                        onTap: () {
                          setState(() {
                            _showUsdBalance = !_showUsdBalance;
                          });
                        },
                        child: _buildBalanceCard(
                          'Pemasukan',
                          _showUsdBalance && usdTotalIncome != null
                              ? currencyFormatUsd.format(usdTotalIncome)
                              : currencyFormatIdr.format(transactionProvider.totalIncome),
                          Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector( // Tambahkan GestureDetector
                        onTap: () {
                          setState(() {
                            _showUsdBalance = !_showUsdBalance;
                          });
                        },
                        child: _buildBalanceCard(
                          'Pengeluaran',
                          _showUsdBalance && usdTotalExpense != null
                              ? currencyFormatUsd.format(usdTotalExpense)
                              : currencyFormatIdr.format(transactionProvider.totalExpense),
                          Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Kurs Mata Uang (IDR ke USD)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _isLoadingExchangeRate
                    ? const Center(child: CircularProgressIndicator())
                    : _exchangeRateError != null
                        ? Center(child: Text(_exchangeRateError!))
                        : _usdExchangeRate != null
                            ? Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('1 USD =', style: TextStyle(fontSize: 16)),
                                      Text(
                                        // Tampilkan 1 USD = berapa IDR
                                        currencyFormatIdr.format(1 / _usdExchangeRate!),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TransactionListScreen()),
                        );
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                transactionProvider.transactions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('Belum ada transaksi. Tambahkan sekarang!'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactionProvider.transactions.length > 5
                            ? 5
                            : transactionProvider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactionProvider.transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 1,
                            child: ListTile(
                              leading: Icon(
                                transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                                color: transaction.type == 'income' ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                transaction.description ?? 'Tanpa Deskripsi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${transaction.category?.name ?? 'Tanpa Kategori'} - ${DateFormat('dd MMM').format(transaction.date)}',
                              ),
                              trailing: Text(
                                
                                _showUsdBalance && _usdExchangeRate != null && _usdExchangeRate! > 0
                                    ? currencyFormatUsd.format(transaction.amount * _usdExchangeRate!)
                                    : currencyFormatIdr.format(transaction.amount),
                                style: TextStyle(
                                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

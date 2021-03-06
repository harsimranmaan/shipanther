import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shipanther/bloc/order/order_bloc.dart';
import 'package:shipanther/l10n/shipanther_localization.dart';
import 'package:shipanther/screens/order/add_edit.dart';
import 'package:shipanther/widgets/filter_button.dart';
import 'package:shipanther/widgets/shipanther_scaffold.dart';
import 'package:trober_sdk/api.dart';
import 'package:shipanther/extensions/order_extension.dart';
import 'package:shipanther/extensions/user_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderList extends StatelessWidget {
  final OrderBloc orderBloc;
  final OrdersLoaded orderLoadedState;
  final User loggedInUser;
  const OrderList(this.loggedInUser,
      {Key key, @required this.orderLoadedState, this.orderBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    var title = ShipantherLocalizations.of(context).ordersTitle;
    List<Widget> actions = [
      FilterButton<OrderStatus>(
        possibleValues: OrderStatus.values,
        isActive: true,
        activeFilter: orderLoadedState.orderStatus,
        onSelected: (t) => context.read<OrderBloc>()..add(GetOrders(t)),
        tooltip: "Filter Order status",
      )
    ];

    Widget body = ListView.builder(
      itemCount: orderLoadedState.orders.length,
      itemBuilder: (BuildContext context, int index) {
        var t = orderLoadedState.orders.elementAt(index);
        return Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.only(left: 20, bottom: 10),
              leading: Icon(t.status.icon),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  orderBloc.add(GetOrder(t.id));
                },
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              title: Text(
                t.serialNumber,
                style: Theme.of(context).textTheme.headline6,
              ),
              children: [
                Text(
                  "Created At: ${formatter.format(t.createdAt).toString()}",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                (t.customer != null)
                    ? Text(
                        "Customer: ${t.customer.name}",
                        style: Theme.of(context).textTheme.subtitle1,
                      )
                    : Text(''),
                Text(
                  "Last Update: ${formatter.format(t.updatedAt).toString()}",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                loggedInUser.isSuperAdmin
                    ? Text(
                        "Tenant ID: ${t.tenantId}",
                        style: Theme.of(context).textTheme.subtitle1,
                      )
                    : Text(''),
              ],
            ),
          ),
        );
      },
    );
    Widget floatingActionButton = FloatingActionButton(
      tooltip: "Add order",
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderAddEdit(
              loggedInUser,
              isEdit: false,
              orderBloc: orderBloc,
              order: Order(),
            ),
          ),
        );
      },
    );

    return ShipantherScaffold(loggedInUser,
        bottomNavigationBar: null,
        title: title,
        actions: actions,
        body: body,
        floatingActionButton: floatingActionButton);
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_rx/types.dart';
import 'package:rxdart/rxdart.dart';

/// Creates a store that holds the app state.
///
/// The only way to change the state in the store is to [dispatch] an
/// action. The action will be sent to the provided [Reducer] to update the state.
///
/// The store will provide actions to each [Effect] after the reducer has
/// been run and a new state has been returned.
///
/// The store can be provided to a widget tree using [StoreProvider].
class Store<State> {
  Store({
    @required State initialState,
    this.reducer,
    this.effects,
  }) {
    assert(initialState != null);
    state.add(initialState);
    if (this.reducer != null) {
      actionStream.listen((StoreAction action) {
        State newState = this.reducer(state.value, action);
        state.add(newState);
        effectsActionStream.add(action);
      });
    }
    if (this.effects != null) {
      effects.forEach((Effect<State> effect) {
        return effect(this.effectsActionStream, this).listen((action) {
          if (action is StoreAction) {
            this.dispatch(action);
          }
        });
      });
    }
  }

  Reducer<State> reducer;
  List<Effect<State>> effects;
  BehaviorSubject<StoreAction> actionStream = BehaviorSubject<StoreAction>();
  BehaviorSubject<StoreAction> effectsActionStream =
      BehaviorSubject<StoreAction>();

  BehaviorSubject<State> state = BehaviorSubject<State>();

  Stream<R> select<R>(Selector<State, R> mapFn) {
    Stream<R> newStream = this.state.map(mapFn).distinct();
    BehaviorSubject<R> subject = BehaviorSubject();
    subject.add(mapFn(this.state.value));
    subject.addStream(newStream);
    return subject;
  }

  dispatch(StoreAction action) {
    actionStream.add(action);
  }
}
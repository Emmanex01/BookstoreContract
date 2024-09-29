#[starknet::interface]
pub trait IBOOKSTORE<TContractState> {
    fn add_book(
        ref self: TContractState,
        book_id: felt252,
        title: felt252,
        author: felt252,
        price: felt252,
        quantity: u8
    );
    fn update_book(
        ref self: TContractState, book_id: felt252, new_price: felt252, new_quantity: u8
    );
    fn rent_book(ref self: TContractState, book_id: felt252, rent_quantity: u8);
    fn book_details(self: @TContractState, book_id: felt252) -> Book;
    fn buy_book(ref self: TContractState, book_id: felt252, buy_quantity: u8);
    fn delete_book(ref self: TContractState, book_id: felt252);
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, starknet::Store)]
struct Book {
    title: felt252,
    author: felt252,
    price: felt252,
    quantity: u8,
}

#[starknet::contract]
pub mod BOOKSTORE {
    use super::{Book, IBOOKSTORE};
    use core::starknet::{
        ContractAddress, get_caller_address,
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, Vec, VecTrait, MutableVecTrait}
    };
    #[storage]
    struct Storage {
        books: Map<felt252, Book>,
        store_owner: ContractAddress,
        stored_books: Vec<(felt252, Book)>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, store_owner: ContractAddress) {
        self.store_owner.write(store_owner)
    }

    #[abi(embed_v0)]
    impl BOOKSTOREImpl of IBOOKSTORE<ContractState> {
        fn add_book(
            ref self: ContractState,
            book_id: felt252,
            title: felt252,
            author: felt252,
            price: felt252,
            quantity: u8
        ) {
            let store_keeper = self.store_owner.read();
            assert(get_caller_address() == store_keeper, 'Only StoreOwner is Allowed');
            let book = Book { title: title, author: author, price: price, quantity: quantity, };
            self.stored_books.append().write((book_id, book));
            self.books.write(book_id, book)
        }
        fn update_book(
            ref self: ContractState, book_id: felt252, new_price: felt252, new_quantity: u8
        ) {
            let store_keeper = self.store_owner.read();
            assert(get_caller_address() == store_keeper, 'Only StoreOwner is Allowed');
            let mut book = self.books.read(book_id);
            book.price = new_price;
            book.quantity += new_quantity;

            self.books.write(book_id, book)
        }
        fn rent_book(ref self: ContractState, book_id: felt252, rent_quantity: u8) {
            // check the storage for the book
            let mut book = self.books.read(book_id);
            // check whether quantity to be rented is greater than available quantity
            assert(book.quantity >= rent_quantity, 'Not Enough Quantity to rent');
            // remove the number rented books
            book.quantity -= rent_quantity;

            self.books.write(book_id, book)
        }
        fn book_details(self: @ContractState, book_id: felt252) -> Book {
            self.books.read(book_id)
        }
        fn buy_book(ref self: ContractState, book_id: felt252, buy_quantity: u8) {
            let mut purchased = self.books.read(book_id);

            assert(purchased.quantity >= buy_quantity, 'Not Enough Quantity to Buy');

            purchased.quantity -= buy_quantity;

            self.books.write(book_id, purchased)
        }
        fn delete_book(ref self: ContractState, book_id: felt252) {
            let store_keeper = self.store_owner.read();
            let caller = get_caller_address();
            assert(caller == store_keeper, 'Only StoreOwner is Allowed');
            let book = Book { title: '', author: '', price: '', quantity: 0, };

            self.books.write(book_id, book)

            let mut index = 0;
            let length = self.stored_books.len();
            while index != length {
                
            }
             
              
            
        }
    }
}


import { LightningElement, wire, track, api } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import getContactFields from '@salesforce/apex/CustomObjectController.getContactFields';
import getContactList from '@salesforce/apex/CustomObjectController.getContactList';
import getListView from '@salesforce/apex/CustomObjectController.GetListView';
import upsertListView from '@salesforce/apex/ListViewController.upsertListView';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import NAMED_FIELD from '@salesforce/schema/Contact.Name';

export default class CustomTabAndFields extends LightningElement {

    //new lists
    @api objectApiName;
    info = [];
    records = [];
    contactList = [];
    columnList = [];
    selectedFieldList = [];
    contactFieldList = [];
    listView = [];

    pageToken = null;
    nextPageToken = null;
    previousPageToken = null;


    @track currentListView = '';
    @track currentListViewLabel = '';

    @track openModal = false;

    @wire(getListView,{
        ObjName : 'Contact',
    }) getList({error,data}){
        if(data){
            var listView = [];
            this.listView = data;
            data.forEach(fieldValue => {
                var value = { 
                    label: fieldValue.Name, 
                    value: fieldValue.DeveloperName 
                };
                listView.push(value);
            },listView);
            this.listView = listView;
            this.currentListView = data[0].DeveloperName;
        }
        else if(error){
            this.error = error;
        }
    }

    @wire(getContactFields) contactFields;

    showModal() {
        this.openModal = true;
    }
    closeModal() {
        this.openModal = false;
    }

    @wire(getListUi,{
        objectApiName : CONTACT_OBJECT,
        listViewApiName : '$currentListView',
        sortby: NAMED_FIELD,
        pageSize: 10,
        pageToken: '$pageToken'
    })listView({ error, data }) {
        if (data) {
            console.log(data);
            this.error = undefined;
            var allRecordIds = [];
            var selectedFieldList = [];
            var contactFieldList = [];
            if(data.records){
                //Set record data and listview info
                this.info = data.info;
                this.records = data.records.records;

                //Set record Id in the UI
                data.records.records.forEach(record => {
                    allRecordIds.push(record.id);
                },allRecordIds);
                this.allRecordIds = allRecordIds;

                //Set columns selected in listview
                data.info.displayColumns.forEach(column => {
                    selectedFieldList.push(column.fieldApiName);
                },selectedFieldList);
                this.selectedFieldList = selectedFieldList;

                //Set all fields in Contact Object
                var fields=this.contactFields.data;
                fields.forEach(field => {
                    var value = { 
                        label: field, 
                        value: field 
                    };
                    contactFieldList.push(value);
                },contactFieldList);
                this.contactFieldList = contactFieldList;

                this.nextPageToken = data.records.nextPageToken;
                this.previousPageToken = data.records.previousPageToken;
            }
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getContactList,{
        recordIds : '$allRecordIds',
        selectedFields: '$selectedFieldList'
    }) contactList({error,data}){
        if(data){
            var columnList = [];
            //Set contect records list
            //this.contactList = data;
            this.contactList = [...data];
            //Set listview columns
            this.info.displayColumns.forEach(column => {
                var col = { 
                    label: column.label, 
                    fieldName: column.fieldApiName, 
                    type:'string' 
                };
                columnList.push(col);
            },columnList);
            this.columnList = columnList;
            console.log(columnList);
            //this.columnList.push(columnList);
        }
        else if(error){
            this.error = error;
        }
    }

    connectedCallback() {
        this.currenObjectName = this.objectApiName;
    }

    updateSelectedFields(event){
        this.selectedFieldList = event.detail.value;
        console.log(this.selectedFieldList);
    }

    updateListView(event){
        this.currentListView = event.detail.value;
        this.currentListViewLabel = event.detail.label;
    }

    handlePreviousPage(event){
        this.pageToken = this.previousPageToken;
    }

    handleNextPage(event){
        console.log(this.nextPageToken);
        this.pageToken = this.nextPageToken;
    }

    saveListView(event){
        this.closeModal();
        upsertListView({ 
            ObjName: 'Contact',
            listName: this.currentListView,
            label: this.currentListViewLabel,
            columns: this.selectedFieldList
        });
        window.location.reload();
    }

    showModal() {
        this.openModal = true;
    }
    closeModal() {
        this.openModal = false;
    }
}